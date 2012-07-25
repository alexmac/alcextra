/*****************************************************************************

gifinter - convert between interlaced and non-interlaced GIFs

*****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdbool.h>

#include "gif_lib.h"
#include "getarg.h"

#define PROGRAM_NAME	"gifinter"

static char
    *VersionStr =
	PROGRAM_NAME
	VERSION_COOKIE
	"	Gershon Elber,	"
	__DATE__ ",   " __TIME__ "\n"
	"(C) Copyright 1989 Gershon Elber.\n";
static char
    *CtrlStr =
	PROGRAM_NAME
	" v%- i%- s%- h%- GifFile!*s";

static int
    ImageNum = 0,
    InterlacedOffset[] = { 0, 4, 2, 1 }, /* The way Interlaced image should. */
    InterlacedJumps[] = { 8, 8, 4, 2 };    /* be read - offsets and jumps... */

static int LoadImage(GifFileType *GifFile, GifRowType **ImageBuffer);
static int DumpImage(GifFileType *GifFile, GifRowType *ImageBuffer);
static void QuitGifError(GifFileType *GifFileIn, GifFileType *GifFileOut);

/******************************************************************************
 Interpret the command line and scan the given GIF file.
******************************************************************************/
int main(int argc, char **argv)
{
    int	NumFiles, ExtCode, ErrorCode;
    bool Error, HelpFlag, SequentialFlag, InterlacedFlag = false;
    GifRecordType RecordType;
    GifByteType *Extension;
    char **FileName = NULL;
    GifRowType *ImageBuffer;
    GifFileType *GifFileIn = NULL, *GifFileOut = NULL;

    if ((Error = GAGetArgs(argc, argv, CtrlStr, &GifNoisyPrint,
		&InterlacedFlag, &SequentialFlag, &HelpFlag,
		&NumFiles, &FileName)) != false ||
		(NumFiles > 1 && !HelpFlag)) {
	if (Error)
	    GAPrintErrMsg(Error);
	else if (NumFiles > 1)
	    GIF_MESSAGE("Error in command line parsing - one GIF file please.");
	GAPrintHowTo(CtrlStr);
	exit(EXIT_FAILURE);
    }

    if (HelpFlag) {
	(void)fprintf(stderr, VersionStr, GIFLIB_MAJOR, GIFLIB_MINOR);
	GAPrintHowTo(CtrlStr);
	exit(EXIT_SUCCESS);
    }

    if (NumFiles == 1) {
	if ((GifFileIn = DGifOpenFileName(*FileName, &ErrorCode)) == NULL) {
	    PrintGifError(ErrorCode);
	    exit(EXIT_FAILURE);
	}
    }
    else {
	/* Use stdin instead: */
	if ((GifFileIn = DGifOpenFileHandle(0, &ErrorCode)) == NULL) {
	    PrintGifError(ErrorCode);
	    exit(EXIT_FAILURE);
	}
    }

    /* Open stdout for the output file: */
    if ((GifFileOut = EGifOpenFileHandle(1, &ErrorCode)) == NULL) {
	PrintGifError(ErrorCode);
	exit(EXIT_FAILURE);
    }

    /* And dump out exactly same screen information: */
    if (EGifPutScreenDesc(GifFileOut,
	GifFileIn->SWidth, GifFileIn->SHeight,
	GifFileIn->SColorResolution, GifFileIn->SBackGroundColor,
	GifFileIn->SColorMap) == GIF_ERROR)
	QuitGifError(GifFileIn, GifFileOut);

    /* Scan the content of the GIF file and load the image(s) in: */
    do {
	if (DGifGetRecordType(GifFileIn, &RecordType) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);

	switch (RecordType) {
	    case IMAGE_DESC_RECORD_TYPE:
		if (DGifGetImageDesc(GifFileIn) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);

		/* Put the image descriptor to out file: */
		if (EGifPutImageDesc(GifFileOut,
		    GifFileIn->Image.Left, GifFileIn->Image.Top,
		    GifFileIn->Image.Width, GifFileIn->Image.Height,
		    InterlacedFlag,
		    GifFileIn->Image.ColorMap) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);

		/* Load the image (either Interlaced or not), and dump it as */
		/* defined in GifFileOut->Image.Interlaced.		     */
		if (LoadImage(GifFileIn, &ImageBuffer) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		if (DumpImage(GifFileOut, ImageBuffer) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		break;
	    case EXTENSION_RECORD_TYPE:
		/* pass through extension records */
		if (DGifGetExtension(GifFileIn, &ExtCode, &Extension) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		if (EGifPutExtensionLeader(GifFileOut, ExtCode) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		if (EGifPutExtensionBlock(GifFileOut, 
					  Extension[0],
					  Extension + 1) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		while (Extension != NULL) {
		    if (DGifGetExtensionNext(GifFileIn, &Extension)==GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    if (Extension != NULL)
			if (EGifPutExtensionBlock(GifFileOut, 
						  Extension[0],
						  Extension + 1) == GIF_ERROR)
			    QuitGifError(GifFileIn, GifFileOut);
		}
		if (EGifPutExtensionTrailer(GifFileOut) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		break;
	    case TERMINATE_RECORD_TYPE:
		break;
	    default:		    /* Should be trapped by DGifGetRecordType. */
		break;
	}
    }
    while (RecordType != TERMINATE_RECORD_TYPE);

    if (DGifCloseFile(GifFileIn) == GIF_ERROR)
	QuitGifError(GifFileIn, GifFileOut);
    if (EGifCloseFile(GifFileOut) == GIF_ERROR)
	QuitGifError(GifFileIn, GifFileOut);

    return 0;
}

/******************************************************************************
 Routine to read Image in. The image can be Interlaced or None interlaced.
 The memory required to hold the image is allocated by the routine itself.
 The image is always loaded sequentially into the buffer.
 Return GIF_OK if successful, GIF_ERROR otherwise.
******************************************************************************/
static int LoadImage(GifFileType *GifFile, GifRowType **ImageBufferPtr)
{
    int Size, i;
    GifRowType *ImageBuffer;

    /* 
     * Allocate the screen as vector of column of rows. Note this
     * screen is device independent - it's the screen defined by the
     * GIF file parameters.
     */
    if ((ImageBuffer = (GifRowType *)
	malloc(GifFile->Image.Height * sizeof(GifRowType))) == NULL)
	    GIF_EXIT("Failed to allocate memory required, aborted.");

    Size = GifFile->Image.Width * sizeof(GifPixelType);/* One row size in bytes.*/
    for (i = 0; i < GifFile->Image.Height; i++) {
	/* Allocate the rows: */
	if ((ImageBuffer[i] = (GifRowType) malloc(Size)) == NULL)
	    GIF_EXIT("Failed to allocate memory required, aborted.");
    }

    *ImageBufferPtr = ImageBuffer;

    GifQprintf("\n%s: Image %d at (%d, %d) [%dx%d]:     ",
	PROGRAM_NAME, ++ImageNum, GifFile->Image.Left, GifFile->Image.Top,
				 GifFile->Image.Width, GifFile->Image.Height);
    if (GifFile->Image.Interlace) {
	int j, Count;
	/* Need to perform 4 passes on the images: */
	for (Count = i = 0; i < 4; i++)
	    for (j = InterlacedOffset[i]; j < GifFile->Image.Height;
						 j += InterlacedJumps[i]) {
		GifQprintf("\b\b\b\b%-4d", Count++);
		if (DGifGetLine(GifFile, ImageBuffer[j], GifFile->Image.Width)
		    == GIF_ERROR) return GIF_ERROR;
	    }
    }
    else {
	for (i = 0; i < GifFile->Image.Height; i++) {
	    GifQprintf("\b\b\b\b%-4d", i);
	    if (DGifGetLine(GifFile, ImageBuffer[i], GifFile->Image.Width)
		== GIF_ERROR) return GIF_ERROR;
	}
    }

    return GIF_OK;
}

/******************************************************************************
 Routine to dump image out. The given Image buffer should always hold the
 image sequentially. Image will be dumped according to the Interlaced flag in
 GifFile structure. Once dumped, the memory holding the image is freed.
 Return GIF_OK if successful, GIF_ERROR otherwise.
******************************************************************************/
static int DumpImage(GifFileType *GifFile, GifRowType *ImageBuffer)
{
    int i, j, Count;

    if (GifFile->Image.Interlace) {
	/* Need to perform 4 passes on the images: */
	for (Count = GifFile->Image.Height, i = 0; i < 4; i++)
	    for (j = InterlacedOffset[i]; j < GifFile->Image.Height;
						 j += InterlacedJumps[i]) {
		GifQprintf("\b\b\b\b%-4d", Count--);
		if (EGifPutLine(GifFile, ImageBuffer[j], GifFile->Image.Width)
		    == GIF_ERROR) return GIF_ERROR;
	    }
    }
    else {
	for (Count = GifFile->Image.Height, i = 0; i < GifFile->Image.Height; i++) {
	    GifQprintf("\b\b\b\b%-4d", Count--);
	    if (EGifPutLine(GifFile, ImageBuffer[i], GifFile->Image.Width)
		== GIF_ERROR) return GIF_ERROR;
	}
    }

    /* Free the memory used for this image: */
    for (i = 0; i < GifFile->Image.Height; i++)
	free((char *) ImageBuffer[i]);
    free((char *) ImageBuffer);

    return GIF_OK;
}

/******************************************************************************
* Close both input and output file (if open), and exit.
******************************************************************************/
static void QuitGifError(GifFileType *GifFileIn, GifFileType *GifFileOut)
{
    if (GifFileIn != NULL) {
	PrintGifError(GifFileIn->Error);
	EGifCloseFile(GifFileIn);
    }
    if (GifFileOut != NULL) {
	PrintGifError(GifFileOut->Error);
	EGifCloseFile(GifFileOut);
    }
    exit(EXIT_FAILURE);
}

/* end */
