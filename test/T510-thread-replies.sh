#!/usr/bin/env bash
#
# Copyright (c) 2013 Aaron Ecay
#

test_description='test of proper handling of in-reply-to and references headers'

# This test makes sure that the thread structure in the notmuch
# database is constructed properly, even in the presence of
# non-RFC-compliant headers'

. $(dirname "$0")/test-lib.sh || exit 1
. $NOTMUCH_SRCDIR/test/test-lib-emacs.sh || exit 1

test_begin_subtest "Use References when In-Reply-To is broken"
add_message '[id]="foo@one.com"' \
    '[subject]=one'
add_message '[in-reply-to]="mumble"' \
    '[references]="<foo@one.com>"' \
    '[subject]="Re: one"'
output=$(notmuch show --format=json 'subject:one' | notmuch_json_show_sanitize)
expected='[[[{"id": "foo@one.com",
 "crypto": {},
 "match": true,
 "excluded": false,
 "filename": ["YYYYY"],
 "timestamp": 978709437,
 "date_relative": "2001-01-05",
 "tags": ["inbox", "unread"],
 "headers": {"Subject": "one",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"},
 "body": [{"id": 1,
 "content-type": "text/plain",
 "content": "This is just a test message (#1)\n"}]},
 [[{"id": "msg-002@notmuch-test-suite",
 "crypto": {},
 "match": true, "excluded": false,
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05",
 "tags": ["inbox", "unread"], "headers": {"Subject": "Re: one",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"},
 "body": [{"id": 1, "content-type": "text/plain",
 "content": "This is just a test message (#2)\n"}]}, []]]]]]'
expected=`echo "$expected" | notmuch_json_show_sanitize`
test_expect_equal_json "$output" "$expected"

test_begin_subtest "Prefer References to dodgy In-Reply-To"
add_message '[id]="foo@two.com"' \
    '[subject]=two'
add_message '[in-reply-to]="Your message of December 31 1999 <bar@baz.com>"' \
    '[references]="<foo@two.com>"' \
    '[subject]="Re: two"'
output=$(notmuch show --format=json 'subject:two' | notmuch_json_show_sanitize)
expected='[[[{"id": "foo@two.com",
 "crypto": {},
 "match": true, "excluded": false,
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "two",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"},
 "body": [{"id": 1, "content-type": "text/plain",
 "content": "This is just a test message (#3)\n"}]},
 [[{"id": "msg-004@notmuch-test-suite", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "Re: two",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"},
 "body": [{"id": 1,
 "content-type": "text/plain", "content": "This is just a test message (#4)\n"}]},
 []]]]]]'
expected=`echo "$expected" | notmuch_json_show_sanitize`
test_expect_equal_json "$output" "$expected"

test_begin_subtest "Use In-Reply-To when no References"
add_message '[id]="foo@three.com"' \
    '[subject]="three"'
add_message '[in-reply-to]="<foo@three.com>"' \
    '[subject]="Re: three"'
output=$(notmuch show --format=json 'subject:three' | notmuch_json_show_sanitize)
expected='[[[{"id": "foo@three.com", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "three",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"}, "body": [{"id": 1,
 "content-type": "text/plain", "content": "This is just a test message (#5)\n"}]},
 [[{"id": "msg-006@notmuch-test-suite", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "Re: three",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"}, "body": [{"id": 1,
 "content-type": "text/plain", "content": "This is just a test message (#6)\n"}]},
 []]]]]]'
expected=`echo "$expected" | notmuch_json_show_sanitize`
test_expect_equal_json "$output" "$expected"

test_begin_subtest "Use last Reference when In-Reply-To is dodgy"
add_message '[id]="foo@four.com"' \
    '[subject]="four"'
add_message '[id]="bar@four.com"' \
    '[subject]="not-four"'
add_message '[in-reply-to]="<baz@four.com> (RFC822 4lyfe)"' \
    '[references]="<baz@four.com> <foo@four.com>"' \
    '[subject]="neither"'
output=$(notmuch show --format=json 'subject:four' | notmuch_json_show_sanitize)
expected='[[[{"id": "foo@four.com", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "four",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"}, "body": [{"id": 1,
 "content-type": "text/plain", "content": "This is just a test message (#7)\n"}]},
 [[{"id": "msg-009@notmuch-test-suite", "match": false, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "neither",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"}, "body": [{"id": 1,
 "content-type": "text/plain", "content": "This is just a test message (#9)\n"}]},
 []]]]], [[{"id": "bar@four.com", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"],
 "timestamp": 978709437, "date_relative": "2001-01-05", "tags": ["inbox", "unread"],
 "headers": {"Subject": "not-four",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "Fri, 05 Jan 2001 15:43:57 +0000"}, "body": [{"id": 1,
 "content-type": "text/plain", "content": "This is just a test message (#8)\n"}]}, []]]]'
expected=`echo "$expected" | notmuch_json_show_sanitize`
test_expect_equal_json "$output" "$expected"

test_begin_subtest "Ignore garbage at the end of References"
add_message '[id]="foo@five.com"' \
    '[subject]="five"'
add_message '[id]="bar@five.com"' \
    '[references]="<foo@five.com> (garbage)"' \
    '[subject]="not-five"'
output=$(notmuch show --format=json 'subject:five' | notmuch_json_show_sanitize)
expected='[[[{"id": "XXXXX", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"], "timestamp": 42, "date_relative": "2001-01-05",
 "tags": ["inbox", "unread"], "headers": {"Subject": "five",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "GENERATED_DATE"}, "body": [{"id": 1,
 "content-type": "text/plain",
 "content": "This is just a test message (#10)\n"}]},
 [[{"id": "XXXXX", "match": true, "excluded": false,
 "crypto": {},
 "filename": ["YYYYY"], "timestamp": 42, "date_relative": "2001-01-05",
 "tags": ["inbox", "unread"],
 "headers": {"Subject": "not-five",
 "From": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "To": "Notmuch Test Suite <test_suite@notmuchmail.org>",
 "Date": "GENERATED_DATE"},
 "body": [{"id": 1, "content-type": "text/plain",
 "content": "This is just a test message (#11)\n"}]}, []]]]]]'
expected=`echo "$expected" | notmuch_json_show_sanitize`
test_expect_equal_json "$output" "$expected"

add_email_corpus threading

test_begin_subtest "reply to ghost"
notmuch show --entire-thread=true id:000-real-root@example.org | grep ^Subject: | head -1 > OUTPUT
cat <<EOF > EXPECTED
Subject: root message
EOF
test_expect_equal_file EXPECTED OUTPUT

test_begin_subtest "reply to ghost (tree view)"
test_emacs '(notmuch-tree "id:000-real-root@example.org")
	    (notmuch-test-wait)
	    (test-output)
	    (delete-other-windows)'
cat <<EOF > EXPECTED
  2016-06-17  Alice                 ??????root message                                        (inbox unread)
  2016-06-18  Alice                 ?????????child message                                      (inbox unread)
  2016-06-17  Mallory                ?????????fake root message                                 (inbox unread)
  2016-06-18  Alice                  ?????????grand-child message                               (inbox unread)
  2016-06-18  Alice                  ????????????great grand-child message                        (inbox unread)
  2016-06-18  Daniel                 ?????????grand-child message 2                             (inbox unread)
End of search results.
EOF
test_expect_equal_file EXPECTED OUTPUT

test_begin_subtest "reply to ghost (RT)"
notmuch show --entire-thread=true id:87bmc6lp3h.fsf@len.workgroup | grep ^Subject: | head -1  > OUTPUT
cat <<EOF > EXPECTED
Subject: FYI: xxxx  xxxxxxx  xxxxxxxxxxxx xxx
EOF
test_expect_equal_file EXPECTED OUTPUT

test_begin_subtest "reply to ghost (RT/tree view)"
test_emacs '(notmuch-tree "id:87bmc6lp3h.fsf@len.workgroup")
	    (notmuch-test-wait)
	    (test-output)
	    (delete-other-windows)'
cat <<EOF > EXPECTED
  2016-06-19  Gregor Zattler       ?????????FYI: xxxx  xxxxxxx  xxxxxxxxxxxx xxx                (inbox unread)
  2016-06-19   via RT              ????????????[support.xxxxxxxxxxx-xxxxxxxxx-xxxxxxxxx.de #33575] AutoReply: FYI: xxxx  xxxxxxx  xxxxxxxxxxxx xxx (inbox unread)
  2016-06-26   via RT              ?????????[support.xxxxxxxxxxx-xxxxxxxxx-xxxxxxxxx.de #33575] Resolved: FYI: xxxx  xxxxxxx  xxxxxxxxxxxx xxx (inbox unread)
End of search results.
EOF
test_expect_equal_file EXPECTED OUTPUT

test_begin_subtest "trusting reply-to (tree view)"
test_emacs '(notmuch-tree "id:B00-root@example.org")
	    (notmuch-test-wait)
	    (test-output)
	    (delete-other-windows)'
cat <<EOF > EXPECTED
  2016-06-17  Alice                 ??????root message                                        (inbox unread)
  2016-06-18  Alice                 ?????????child message                                      (inbox unread)
  2016-06-18  Alice                  ?????????grand-child message                               (inbox unread)
End of search results.
EOF
test_expect_equal_file EXPECTED OUTPUT

test_done
