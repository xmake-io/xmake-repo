#pragma once

#ifdef _MSC_VER
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#else
typedef int ssize_t;
#endif
