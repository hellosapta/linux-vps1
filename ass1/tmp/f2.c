
#include <stdio.h>

int main() {
    int n,d;
    printf("TThis if file-1");
    printf("Enter a number");
    scanf("%d",&n);
    printf("Enter the divisor");
    scanf("%d",&d);
    if(n%d==0) printf("YOur number is divisable by %d",d);
    else printf("Number is not divisible by %d",d);
    return 0;
}
