
#include <stdio.h>

int main() {
    int n;
    printf("Enter a number :");
    scanf("%d",&n);
    for(int i=2;i<n;i++){
        if(n%i==0){
            printf("Your numver is not prime");
            return 0;
        }
    }
    printf("YOur number is prime!");
    return 0;
}
