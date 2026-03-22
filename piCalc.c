/*
 * Pi calculator - arbitrary precision
 * Uses Machin formula: pi = 16*arctan(1/5) - 4*arctan(1/239)
 * arctan(x) = x - x^3/3 + x^5/5 - x^7/7 + ...
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PRECISION 100
#define SIZE (PRECISION + 20)

typedef struct {
    int *d;
} Big;

static void big_init(Big *n) {
    n->d = calloc(SIZE, sizeof(int));
}

static void big_free(Big *n) {
    free(n->d);
}

static void big_set(Big *n, int val) {
    memset(n->d, 0, SIZE * sizeof(int));
    for (int i = SIZE - 1; val > 0; val /= 10)
        n->d[i--] = val % 10;
}

static void big_copy(Big *dst, Big *src) {
    memcpy(dst->d, src->d, SIZE * sizeof(int));
}

static void big_add(Big *dst, Big *src) {
    int carry = 0;
    for (int i = SIZE - 1; i >= 0; i--) {
        int s = dst->d[i] + src->d[i] + carry;
        dst->d[i] = s % 10;
        carry = s / 10;
    }
}

static void big_sub(Big *dst, Big *src) {
    int borrow = 0;
    for (int i = SIZE - 1; i >= 0; i--) {
        int s = dst->d[i] - src->d[i] - borrow;
        if (s < 0) { s += 10; borrow = 1; }
        else borrow = 0;
        dst->d[i] = s;
    }
}

static void big_mul(Big *n, int val) {
    int carry = 0;
    for (int i = SIZE - 1; i >= 0; i--) {
        int p = n->d[i] * val + carry;
        n->d[i] = p % 10;
        carry = p / 10;
    }
}

static void big_div(Big *n, int val) {
    int rem = 0;
    for (int i = 0; i < SIZE; i++) {
        int cur = rem * 10 + n->d[i];
        n->d[i] = cur / val;
        rem = cur % val;
    }
}

static int big_is_zero(Big *n) {
    for (int i = SIZE - PRECISION - 5; i < SIZE; i++)
        if (n->d[i] != 0) return 0;
    return 1;
}

static void big_print(Big *n) {
    int start = 0;
    while (start < SIZE && n->d[start] == 0) start++;

    putchar('3');
    putchar('.');

    int printed = 0;
    for (int i = start + 1; printed < PRECISION && i < SIZE; i++, printed++)
        putchar('0' + n->d[i]);
    putchar('\n');
}

/*
 * arctan(1/x) = sum_{n=0}^{inf} (-1)^n / ((2n+1) * x^(2n+1))
 * term[n] = term[n-1] * (2n-1) / ((2n+1) * x^2)
 */
static void arctan(Big *result, int x) {
    Big term;
    big_init(&term);

    big_set(result, 0);
    big_set(&term, 0);
    term.d[SIZE - PRECISION - 5] = 1;

    big_div(&term, x);

    int numer = 1;
    int denom = x;

    for (;;) {
        big_add(result, &term);

        big_mul(&term, numer);
        big_div(&term, denom * denom);
        big_div(&term, numer + 2);

        numer += 2;

        big_sub(result, &term);

        big_mul(&term, numer);
        big_div(&term, denom * denom);
        big_div(&term, numer + 2);

        numer += 2;

        if (big_is_zero(&term)) break;
    }

    big_free(&term);
}

int main(void) {
    Big pi, a1, a2;
    big_init(&pi);
    big_init(&a1);
    big_init(&a2);

    arctan(&a1, 5);
    big_mul(&a1, 16);

    arctan(&a2, 239);
    big_mul(&a2, 4);

    big_copy(&pi, &a1);
    big_sub(&pi, &a2);

    big_print(&pi);

    big_free(&pi);
    big_free(&a1);
    big_free(&a2);
    return 0;
}
