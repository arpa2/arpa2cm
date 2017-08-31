/* Check if log4cpp compiles and links */
/* Example code from the log4cpp documentation */

#include <string>
namespace log4cpp {
class Category {
public:
        static Category& getInstance(const std::string& name);
} ;
}

int main(int argc, char** argv) {
	log4cpp::Category::getInstance(std::string("sub1"));
	return 0;
}

