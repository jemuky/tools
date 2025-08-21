// rdseed.c
#include <immintrin.h>

#ifdef _WIN32
__declspec(dllexport)
#endif
    int true_rand(unsigned long long *val) {
  return _rdseed64_step(val);
}