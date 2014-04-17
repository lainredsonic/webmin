package Webmin::API;

require 5.005_62;

require Exporter;

#Perl类（包）的继承是通过@ISA数组来实现的
#简单来说，Perl把它看作目录名的特殊数组，与@INC数组类似（@INC数组是包含引用路径）
#当Perl在当前类（包）中无法找到所需方法时，便会在该数组列出的类中查找。
our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

#该类默认导出的符号
our @EXPORT = (
	'$config_directory',
	'$var_directory',
	'$remote_error_handler',
	'%month_to_number_map',
	'%number_to_month_map',
	'$config_file',
	'%gconfig',
	'$null_file',
	'$path_separator',
	'$root_directory',
	'$module_name',
	'@root_directories',
	'$base_remote_user',
	'$remote_user',
	'$module_config_directory',
	'$module_config_file',
	'%config',
	'$current_theme',
	'$theme_root_directory',
	'%tconfig',
	'$tb',
	'$cb',
	'$scriptname',
	'$webmin_logfile',
	'$current_lang',
	'$current_lang_info',
	'@lang_order_list',
	'%text',
	'%module_info',
	'$module_root_directory',
	'$default_lang',
	);

our $VERSION = '1.0';

# Find old symbols by Webmin import
my %oldsyms = %Webmin::API::;

# Preloaded methods go here.
$main::no_acl_check++;

#/etc/webmin/miniserv.conf 是主配置文件
$ENV{'WEBMIN_CONFIG'} ||= "/etc/webmin";
$ENV{'WEBMIN_VAR'} ||= "/var/webmin";
open(MINISERV, $ENV{'WEBMIN_CONFIG'}."/miniserv.conf") ||
	die "Could not open Webmin config file ".
	    $ENV{'WEBMIN_CONFIG'}."/miniserv.conf : $!";
my $webmin_root;
while(<MINISERV>) {
	s/\r|\n//g;
	if (/^root=(.*)/) {
		$webmin_root = $1;
		}
	}
close(MINISERV);

#找到了webmin_root也就是所有perl代码的地方，缺省为/usr/libexec/webmin
$webmin_root || die "Could not find Webmin root directory";
chdir($webmin_root);

#将脚本名移到$webmin_root下, 作用未知
if ($0 =~ /\/([^\/]+)$/) {
	$0 = $webmin_root."/".$1;
	}
else {
	$0 = $webmin_root."/api.pl";	# Fake name
	}

#执行web-lib.pl 和 web-lib-funcs.pl
require './web-lib.pl';
&init_config();

# Export core symbols
foreach my $lib ("$webmin_root/web-lib.pl",
		 "$webmin_root/web-lib-funcs.pl") {
	open(WEBLIB, $lib);
	while(<WEBLIB>) {
		if (/^sub\s+([a-z0-9\_]+)/i) {
# 将web-lib.pl 和 web-lib-funcs.pl 中所有的函数导出
			push(@EXPORT, $1);
			}
		}
	close(WEBLIB);
	}

#按要求导出符号，也就是在use的时候必须要特殊制定qw()  
our @EXPORT_OK = ( @EXPORT );

1;
__END__

=head1 NAME

Webmin::API - Perl module to make calling of Webmin functions from regular
              command-line Perl scripts easier.

=head1 SYNOPSIS

  use Webmin::API;
  @pids = &find_byname("httpd");
  foreign_require("cron", "cron-lib.pl");
  @jobs = &cron::list_cron_jobs();

=head1 DESCRIPTION

This module just provides a convenient way to call Webmin API functions
from a script that is not run as a Webmin CGI, without having to include a 
bunch of boilerplate initialization code at the top. It's main job is to export
all API functions into the namespace of the caller, and to setup the Webmin
environment.

=head2 EXPORT

All core Webmin API functions, like find_byname, foreign_config and so on.

=head1 AUTHOR

Jamie Cameron, jcameron@webmin.com

=head1 SEE ALSO

perl(1).

=cut

