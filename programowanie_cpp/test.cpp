#include <string>
#include <cstring>
#include <iostream>
#include <vector>

// const std::string& means the string won't be copied and won't be modified
std::string repeat (int n, const std::string& s) {
    std::string res;
    for (int i=0; i <= n-1; i++) {
        std::cout << s;
    }
    return res;
}

//class A {
//public:
//    std::ostream& operator<<(std::ostream& os) const {
//        os << "Hello from class A";
//        return os;
//    }
//
//};
#include <iostream>
#include <vector>

class A {
public:
    A() {
        std::cout << "A constructor" << std::endl;
    }

    ~A() {
        std::cout << "A destructor" << std::endl;
    }
};

class B {
public:
    std::vector<A*> v;

    void add(A& a) {
        v.push_back(new A(a));
    }

    ~B() {

        v.clear();

        std::cout << "B destructor used" << std::endl;
        if (v.empty()) {
            std::cout << "Vector is empty" << std::endl;
        } else {
            std::cout << "Vector is not empty" << std::endl;
        }
    }
};

int main() {
    B b;
    A a1;
    A a2;
    b.add(a1);
    b.add(a2);

    std::cout << "Main function end" << std::endl;

    return 0;


//    A a;
//    std::cout << a;
//    std::string name = "Kasia";
//
//    //include whitespace
//    const wchar_t* name2 = L"Whoop";
//    name += " hihi";
//    std::cout << name << std::endl;
//    std::cout << name.size() << std::endl;
//    const char* title = "mgr";
//    std::cout << std::strlen(title) << std::endl;
//    repeat(3, "Hi");
    const int age = 90;
    //this means you cannot change the data in the pointer
    //const int* == int const*
    const int* a = new int;

    // this means that pointer can't be reassigned to sth else
//    int* const b = new int;

    //const on both
    const int* const c = new int;

    //*a = 2;
    //reassign the pointer
    //b = 10;
    a = (int*)&age;
    std::cout << a << std::endl;
    std::cout << *a << std::endl;

}