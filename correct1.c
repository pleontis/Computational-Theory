#include "thetalib.h"
#include <math.h>

const int N = -100;
int a,b;
int cube(int i){
	return i * i * i;
}
int add(int n,int k){
	int j;
	j=(N - n) + cube(k);
	writeInteger(j);
	return j;
}
void main(){
	a=readInteger();
	b=readInteger();
	add(a , b);
}

