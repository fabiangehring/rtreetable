
test_that("levelsToGroups", {
  levels <- rep(c(1, 2, 2, 1, 2, 3, 3, 2, 1), 2)
  res <- rep(c("1_exp", "11", "12", "2_exp", "21_exp", "211", "212", "22", "3"), 2)
  expect_equal(levelsToGroups(levels), res)
})
