
test_that("levelsToGroups", {
  levels <- c(1, 2, 2, 1, 2, 3, 3, 2, 1)
  res <- c("1+", "11", "12", "2+", "21+", "211", "212", "22", "3")
  expect_equal(levelsToGroups(levels), res)
})
