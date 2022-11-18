//318868312 Noam Lahmani
#include <stdio.h>
#include <stdbool.h>
#include "ex1.h"

/*
The function calculates a power by multiply x for n times
*/
long power(int x, unsigned n)
{
    long long pow = 1;
    int i;
    for (i = 0; i < n; i++) {
        pow = pow * x;
    }
    return pow;
}

/*
Convertion the represention of digit '1' from bytes to an array of char.
If the represtion is big endian, then the value of the first byte is zero. The method returns '1'.
Else, it is little endian, and the method returns '0'.
*/
int is_big_endian(){
   long num = 1;
   char *c = (char *)&num;
   if (*c == 0)
   {
      //big endian
      return 1;
   }
    return 0;
}


/*
binary array defined by bitArray- true=1, false = 0
rightmost bit - MSB
calculate the value of the bits, not including the rightmost bit
(using  help-function "power" to calculate the power)
if the rightmost bit of bitArray is 1 - turn the number to negative
return the number
*/
int get_sign_magnitude(bool bitArray[8]){
 
   int size = 8;
   int decimal_number = 0;
   int binary[size-1]; 
   int i;
   for(i=0; i<size-1; i++){
      if(bitArray[i] == true){
         binary[i] = 1;
      }
      else{
         binary[i] = 0;
      }
   }
   for(i = 0; i<size-2; i++){ 
      decimal_number += binary[i] * power(2,i);
   }

   if(bitArray[7] == true){
      decimal_number = (-1) * decimal_number;
   }

   return decimal_number;
}


/*
   ones_complement array defined by bitArray- true=0, false = 1
   create one_complement array by flipping all bits
   create twos_complement by the carry 
   if the rightmost bit of bitArray is 1 - turn the number to negative

*/
int get_two_comp(bool bitArray[8]){
   int size = 8;
   int ones_complement[size], twos_complement[size]; 
   int carry = 1;
   int decimal_number = 0;
   int i;
   for(i=0; i<size; i++){
      if(bitArray[i] == true){
         ones_complement[size-1-i] = 0;
      }
      else{
         ones_complement[size-1-i] = 1;
      }
   }

   for(i = size-1; i>=0; i-- ){
      if(carry == 1){
         if(ones_complement[i] == 1){
            twos_complement[i] = 0;
         }
         else{
            twos_complement[i] = 1;
            carry = 0;
         }
      }
      else{
         twos_complement[i] = ones_complement[i];
      }
   }
    for(i = 0; i<size-1; i++){ 
      decimal_number += twos_complement[size-1-i] * power(2,i);
   }

   if(bitArray[size-1] == 1){
      decimal_number = (-1) * decimal_number;
   }
   return decimal_number;
}

