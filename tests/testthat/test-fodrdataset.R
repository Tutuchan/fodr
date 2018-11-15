context("test-fodrdataset")

test_that("fodr_dataset works") {
  expect_is(fodr_dataset("ods", "correspondance-code-insee-code-postal"), "FODRDataset")
}

test_that("get_records works", {
  dts <- fodr_dataset("ods", "correspondance-code-insee-code-postal")
  expect_is(df <- dts$get_records(nrows = 10), "tbl_df")
  expect_equal(nrow(df), 10)
})
