// ssize_t_fix.h - Fix for ssize_t redefinition on Windows
// This header is force-included to define ssize_t before VLC headers

#ifndef SSIZE_T_FIX_H
#define SSIZE_T_FIX_H

#if defined(_MSC_VER) && !defined(_SSIZE_T_DEFINED)
#include <basetsd.h>
typedef SSIZE_T ssize_t;
#define _SSIZE_T_DEFINED
#endif

#endif // SSIZE_T_FIX_H
