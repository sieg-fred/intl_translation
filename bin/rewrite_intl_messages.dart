#!/usr/bin/env dart
// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A main program that imitates the action of the transformer, adding
/// name and args parameters to Intl.message calls automatically.
///
/// This is mainly intended to test the transformer logic outside of barback.
/// It takes as input a single source Dart file and rewrites any
/// Intl.message or related calls to automatically include the name and args
/// parameters and writes the result to stdout.
///
import 'dart:io';

import 'package:args/args.dart';

import 'package:intl_translation/src/message_rewriter.dart';

String outputFile = 'transformed_output.dart';

bool useStringSubstitution = true;

main(List<String> args) {
  var parser = new ArgParser();
  parser.addOption('output',
      defaultsTo: 'transformed_output.dart',
      callback: (x) => outputFile = x,
      help: 'Specify the output file.');
  parser.addFlag('useStringSubstitution',
      defaultsTo: true,
      callback: (x) => useStringSubstitution = x,
      help: 'If true, in rewriting, try to leave the text of the message'
          ' as close to the original as possible. This is slightly less reliable,'
          ' because it relies on string matching, but better for updating'
          ' source code to move away from the transformer. If false,'
          ' behave like the transformer, regenerating the message code'
          ' from our internal representation. This is more reliable, but'
          ' produces less readable code.');
  print(args);
  parser.parse(args);
  if (args.length == 0) {
    print('Accepts a single Dart file and adds "name" and "args" parameters '
        ' to Intl.message calls.');
    print('Primarily useful for exercising the transformer logic or '
        'for rewriting programs to not require the transformer.');
    print('Usage: rewrite_intl_messages [options] [file.dart]');
    print(parser.usage);
    exit(0);
  }
  var dartFile = args.where((x) => x.endsWith(".dart")).last;
  var file = new File(dartFile);
  var content = file.readAsStringSync();
  var newSource = rewriteMessages(content, '$file',
      useStringSubstitution: useStringSubstitution);
  if (content == newSource) {
    print("No changes to $outputFile");
  } else {
    print('Writing new source to $outputFile');
    var out = new File(outputFile);
    out.writeAsStringSync(newSource);
  }
}