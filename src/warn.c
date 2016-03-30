#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/param.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>

#include "mruby.h"
#include "mruby/variable.h"
#include "mruby/string.h"
#include "mruby/data.h"
#include "mruby/class.h"
#include "mruby/value.h"
#include "mruby/array.h"
#include "mruby/hash.h"
#include "mruby/numeric.h"
#include "mruby/compile.h"

mrb_value mrb_k_warn(mrb_state *mrb, mrb_value self) {
  mrb_value *argv;
  mrb_int i, argc;
  mrb_get_args(mrb, "*", &argv, &argc);
  for (i = 0; i < argc; i++) {
    if (mrb_string_p(argv[i])) {
      fwrite(RSTRING_PTR(argv[i]), RSTRING_LEN(argv[i]), 1, stderr);
      fwrite("\n", 1, 1, stderr);
    }
    else if (mrb_array_p(argv[i])) {
      mrb_sym m_sym = mrb->c->ci->mid; // get symbol for this method
      mrb_funcall_argv(mrb, self, m_sym, RARRAY_LEN(argv[i]), RARRAY_PTR(argv[i]));
    }
    else {
      mrb_value str = mrb_obj_as_string(mrb, argv[i]);
      fwrite(RSTRING_PTR(str), RSTRING_LEN(str), 1, stderr);
      fwrite("\n", 1, 1, stderr);
    }
  }
  return mrb_nil_value();
}


