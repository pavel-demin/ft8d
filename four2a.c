#include "pffft.h"

static struct
{
    PFFFT_Setup *s;
    int n;
} setups[10];

static int size;

void four2a_(float *a, int *nfft, int *ndim, int *sign, int *form)
{
    int i;
    PFFFT_Setup *s;
    pffft_direction_t direction;

    s = NULL;
    for(i = 0; i < size; ++i)
    {
        if(setups[i].n == *nfft)
        {
            s = setups[i].s;
            break;
        }
    }

    if(s == NULL && size < 10)
    {
        s = pffft_new_setup(*nfft, PFFFT_COMPLEX);
        setups[size].s = s;
        setups[size].n = *nfft;
        ++size;
    }

    if(s != NULL)
    {
        direction = *sign == 1 ? PFFFT_BACKWARD : PFFFT_FORWARD;
        pffft_transform_ordered(s, a, a, NULL, direction);
    }
}
