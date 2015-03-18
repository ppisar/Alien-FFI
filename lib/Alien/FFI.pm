package Alien::FFI;

use strict;
use warnings;
use Config;
use base qw( Alien::Base );

# ABSTRACT: Build and make available libffi
# VERSION

sub libs
{
  my $class = shift;
  
  my $libs = $class->SUPER::libs(@_);

  if($class->install_type eq 'share'
  && !$class->config('finished_installing'))
  {
    my $working_dir = $class->config('working_directory');
    $libs = "-L$working_dir/.libs -lffi";
  }
  
  if($^O eq 'openbsd' && !$Config{usethreads} && Alien::FFI->install_type eq 'share')
  {
    $libs .= ' /usr/lib/libpthread.a';
  }
  
  if($^O eq 'MSWin32' && $Config{ccname} eq 'cl')
  {
    $libs =~ s{-L}{/LIBPATH:}g;
    $libs =~ s{-l([A-Za-z]+)}{$1.LIB}g;
  }
  
  $libs;
}

sub cflags
{
  my $class = shift;
  
  my $cflags = $class->SUPER::cflags(@_);
  
  if($class->install_type eq 'share'
  && !$class->config('finished_installing'))
  {
    my $working_dir = $class->config('working_directory');
    $cflags = "-I$working_dir/include";
  }

  if($class->install_type eq 'share'
  && $^O eq 'MSWin32'
  && $Config{ccname} eq 'cl')
  {
    $cflags .= " -DFFI_BUILDING";
  }  
  
  $cflags;
}

=head1 SYNOPSIS

In your C<Build.PL>:

 use Alien::FFI;
 use Module::Build;
 
 my $build = Module::Build->new(
   ...
   extra_compiler_flags => Alien::FFI->cflags,
   extra_linker_flags   => Alien::FFI->libs,
   ...
 );
 
 $build->create_build_script;

=head1 DESCRIPTION

This distribution installs libffi so that it can be used by other Perl distributions.  If already
installed for your operating system, and it can be found, this distribution will use the libffi
that comes with your operating system, otherwise it will download it from the Internet, build and
install it for you.

=head1 SEE ALSO

=over 4

=item L<FFI::Platypus>

Write Perl bindings to non-Perl libraries without C or XS

=item L<FFI::CheckLib>

Check that a library is available for FFI

=back

=cut

1;
