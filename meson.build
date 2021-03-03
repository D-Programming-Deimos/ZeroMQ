project('zeromq', 'd',
	version: '6.1.2+zmq-4-3-2',
	license: 'LGPL-3')

libzmq_dep = dependency('libzmq', version: '>=4.3')

zeromq_dep = declare_dependency(
	include_directories: ['.'],
	version: meson.project_version(),
	dependencies: libzmq_dep,
)
