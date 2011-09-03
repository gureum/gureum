require 'mkmf'

dir_config('hangul')
have_library('hangul', 'hangul_ic_new')
create_makefile('hangul')

# vim: set sts=2 sw=2 et:
