/// Selects host-platform facts without making the public library web-unsafe.
library;

export 'miuix_host_platform_stub.dart'
    if (dart.library.io) 'miuix_host_platform_io.dart';
