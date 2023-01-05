#include "thetalib.h"
#include <math.h>

int next_random;
int next(){
	next_random=fmod((next_random * 1103515245 + 12345),2147483648);
	if(next_random < 0){
		next_random=-next_random;

	}
	return next_random;
}
void swap(int a[],int i,int j){
	int temp;
	temp=a[(int)(i)];
	a[(int)(i)]=a[(int)(j)];
	a[(int)(j)]=temp;
}
void quickSort(int a[],int low,int high){
	int pivot,i,j;
	if(low < high){
		pivot=low;
	i=low;
	j=high;
	while(i < j){
		while(a[(int)(i)] <= a[(int)(pivot)] && i < high){
		i=i + 1;
	}
	while(a[(int)(j)] > a[(int)(pivot)]){
		j=j - 1;
	}
	if(i < j){
		swap(a , i , j);

	}
	}
	swap(a , pivot , j);
	quickSort(a , low , j - 1);
	quickSort(a , j + 1 , high);

	}
}
void printArray(int a[],int size){
	for(int i=0;i<=size && i>=-size;i+=1){
	writeInteger(a[(int)(i)]);
	if(i == size - 1){
		continue;

	}
	writeStr(", ");

}
	writeStr("\n");
}
void main(){
	const int aSize = 100;
	int a[(int)(100)];
	writeStr("Give a seed for the random number generator: ");
	readInteger(next_random);
	for(int i=0;i<=aSize && i>=-aSize;i+=1){
	a[(int)(i)]=fmod(next(),1000);

}
	writeStr("Random array generated: ");
	printArray(a , aSize);
	quickSort(a , 0 , aSize - 1);
	writeStr("Sorted array: ");
	printArray(a , aSize);
}

