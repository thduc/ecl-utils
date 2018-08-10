IMPORT Std.Str;

EXPORT DataGenUtils := MODULE

  EXPORT UNSIGNED MAX_RANDOM := 4294967295;
  EXPORT STRING DIGITS := '0123456789';
  EXPORT STRING LOWER_LETTERS := 'abcdefghijklmnopqrstuvwxyz';
  EXPORT STRING UPPER_LETTERS := Str.ToUpperCase(LOWER_LETTERS);
  EXPORT STRING LETTERS := UPPER_LETTERS + LOWER_LETTERS;
  EXPORT STRING ALPHA := DIGITS + LETTERS;

  /*
    Generate random unsigned int between 0 and MAX_RANDOM (4294967295).
  */
  EXPORT UNSIGNED NextUnsigned() := RANDOM();

  /*
    Generate random float between 0 and 1.
  */
  EXPORT REAL8 NextDouble() := FUNCTION
    RETURN (REAL8) NextUnsigned() / MAX_RANDOM;
  END;

  /*
    Generate random boolean.
  */
  EXPORT BOOLEAN NextBoolean() := FUNCTION
    RETURN (NextUnsigned() >= (MAX_RANDOM >> 0x01));
  END;

  /*
    Generate random string of given length from a given characters set.
  */
  EXPORT STRING NextString(UNSIGNED len, STRING charsets = ALPHA) := BEGINC++
    #option action
    #include <pthread.h>
    #include <stdlib.h>
    #include <time.h>
    #body

    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_lock(&mutex);
    srand(time(NULL) + rand());
    char* out = len > 0 ? (char*)rtlMalloc(len) : NULL;
    unsigned t;
    double scale = (double)lenCharsets / RAND_MAX;
    for (unsigned i = 0; i < len; i++) {
      t = rand() * scale;
      out[i] = charsets[t];
    }
    pthread_mutex_unlock(&mutex);
    __lenResult = len;
    __result = out;
  ENDC++;

  SHARED DataGenShared := MODULE, VIRTUAL
    SHARED UNSIGNED MAXRANDOM := MAX_RANDOM;
    SHARED UNSIGNED NextRandomUnsigned() := RANDOM();
  END;

  /*
    Create module for bounded random numerical values.
  */
  EXPORT CreateHelperModuleForRandomNumericalValue(REAL8 end1 = 0, REAL8 end2 = MAX_RANDOM) := FUNCTION
    Mod := MODULE(DataGenShared)
      SHARED REAL8 LowerBound := IF(end1 < end2, end1, end2);
      SHARED REAL8 UpperBound := IF(end1 < end2, end2, end1);
      SHARED REAL8 RangeWidth := UpperBound - LowerBound;
      SHARED REAL8 Scale := RangeWidth / MAXRANDOM;
      SHARED BOOLEAN IsBounded := (LowerBound != 0) OR (UpperBound != MAXRANDOM);
      /*
        Generate random bounded integer.
      */
      EXPORT INTEGER NextInt() := FUNCTION
        v := NextRandomUnsigned();
        RETURN IF(IsBounded, LowerBound + v * Scale, v);
      END;
      /*
        Generate random bounded float.
      */
      EXPORT REAL8 NextDouble() := FUNCTION
        REAL8 v := NextRandomUnsigned();
        RETURN IF(IsBounded, LowerBound + v * Scale, v / MAXRANDOM);
      END;
    END;
    RETURN Mod;
  END;

  /*
    Create module for random strings of given length from predefined characters set.
  */
  EXPORT CreateHelperModuleForRandomString(UNSIGNED stringLength, STRING characterSets = ALPHA) := FUNCTION
    Mod := MODULE
      /*
        Generate random string of given length from a given characters set.
      */
      EXPORT STRING NextString(UNSIGNED len = stringLength, STRING charsets = characterSets) := NextString(len, charsets);
    END;
    RETURN Mod;
  END;

END;
