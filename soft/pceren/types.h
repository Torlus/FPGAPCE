/*
 * types.h
 *
 * Fundamental data types
 *
 * NOTE: This file may require porting!
 */

#ifndef INCLUDED_TYPES_H
#define INCLUDED_TYPES_H

/*****************************************************************************
 Macros
 
 Compiler or system-specific macros.
*****************************************************************************/

#define PACKED	__attribute__ ((packed))	// do not pad struct members


/*****************************************************************************
 Generic Data Types

 These data types are for general purpose use where data type size is not an
 explicit concern.
*****************************************************************************/

/*
 * Arbitrary data types: Requirements for these are project-specific; pose
 * the greatest compatibility risk
 */

typedef unsigned int        FLAGS;  // for storing flags, size arbitrarily
                                    // determined by project
typedef float				FLOAT;	// general floating point data type

/*
 * Variable length data types: Must meet the minimum length requirements
 */

typedef int                 BOOL;   // boolean flag (at least 1 bit)
typedef unsigned int        UINT;   // unsigned integer (at least 32 bits,
                                    // preferrably the optimal integer and
                                    // address size for given architecture)
typedef signed int          INT;    // signed integer (same as above)
typedef unsigned char       UCHAR;  // unsigned character (should be 8 bits)
typedef signed char         CHAR;   // signed character (same as above),
                                    // intended for text


/*****************************************************************************
 Specific Data Types

 Data types which must be the implied number of bits.
*****************************************************************************/

typedef unsigned long long  UINT64; // unsigned 64-bit integer (quad word)
typedef signed long long    INT64;  // signed 64-bit integer (quad word)
typedef unsigned int        UINT32; // unsigned 32-bit integer (double word)
typedef signed int          INT32;  // signed 32-bit integer (double word)
typedef unsigned short      UINT16; // unsigned 16-bit integer (word)
typedef signed short        INT16;  // signed 16-bit integer (word)
typedef unsigned char       UINT8;  // unsigned 8-bit integer (byte)
typedef signed char         INT8;   // signed 8-bit integer (byte)


#endif  // INCLUDED_TYPES_H
