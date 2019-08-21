#!/usr/bin/env bats

@test "addition using bc" {
  result="$(echo 2+2 | bc)"
  [ "$result" -eq 4 ]
}

@test "Missing DYNU_APIKEY" {
  ../testing.sh
  assert_failure
  assert_output -p "DYNU_APIKEY is missing"
}

