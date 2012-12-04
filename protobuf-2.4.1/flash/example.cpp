#include <iostream>
#include <fstream>
#include <string>
#include "example.pb.h"
using namespace std;

// Main function:  Reads the entire address book from a file,
//   adds one person based on user input, then writes it back out to the same
//   file.
int main(int argc, char* argv[]) {
  // Verify that the version of the library that we linked against is
  // compatible with the version of the headers we compiled against.
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  std::cout << "Creating AddressBook...\n";

  tutorial::AddressBook address_book;
  tutorial::Person* person = address_book.add_person();

  person->set_id(42);
  *person->mutable_name() = std::string("Alchemist");
  person->set_email("alchemist@example.com");

  tutorial::Person::PhoneNumber* phone_number = person->add_phone();
  phone_number->set_number("415-000-0000");
  phone_number->set_type(tutorial::Person::MOBILE);

  std::cout << "Serializing AddressBook:\n";
  address_book.SerializeToOstream(&std::cout);

  // Optional:  Delete all global objects allocated by libprotobuf.
  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}