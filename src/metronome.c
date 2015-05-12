/***************************************************************************/
/*                                                                         */
/* metronome.c - mruby gem provoding FSM                                   */
/* Copyright (C) 2015 Paolo Bosetti and Matteo Ragni,                      */
/* paolo[dot]bosetti[at]unitn.it and matteo[dot]ragni[at]unitn.it          */
/* Department of Industrial Engineering, University of Trento              */
/*                                                                         */
/* This library is free software.  You can redistribute it and/or          */
/* modify it under the terms of the GNU GENERAL PUBLIC LICENSE 2.0.        */
/*                                                                         */
/* This library is distributed in the hope that it will be useful,         */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of          */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           */
/* Artistic License 2.0 for more details.                                  */
/*                                                                         */
/* See the file LICENSE                                                    */
/*                                                                         */
/***************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "mruby.h"
#include "mruby/variable.h"
#include "mruby/string.h"
#include "mruby/data.h"
#include "mruby/class.h"
#include "mruby/value.h"

static mrb_value mrb_ualarm(mrb_state *mrb, mrb_value self) {
  mrb_int initial, recurring;
  useconds_t remaining;
  mrb_get_args(mrb, "ii", &initial, &recurring);
  if (initial < 0 || recurring < 0) {
    mrb_raise(mrb, E_RUNTIME_ERROR, "Positive values only!");
  }
  remaining = ualarm((useconds_t)initial, (useconds_t)recurring);
  return mrb_fixnum_value(remaining);
}

static mrb_value mrb_alarm(mrb_state *mrb, mrb_value self) {
  mrb_int delay;
  useconds_t remaining;
  mrb_get_args(mrb, "i", &delay);
  if (delay < 0 ) {
    mrb_raise(mrb, E_RUNTIME_ERROR, "Positive values only!");
  }
  remaining = alarm((useconds_t)delay);
  return mrb_fixnum_value(remaining);
}


void mrb_mruby_fsm_gem_init(mrb_state *mrb) {
  struct RClass *metro;
  metro = mrb_define_module(mrb, "Metronome");
  mrb_define_class_method(mrb, metro, "ualarm", mrb_ualarm, MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, metro, "alarm", mrb_alarm, MRB_ARGS_REQ(1));
}

void mrb_mruby_fsm_gem_final(mrb_state *mrb) {}
