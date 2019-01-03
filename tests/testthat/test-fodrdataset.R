context("test-fodrdataset")

test_that("fodr_dataset works", {
  expect_is(fodr_dataset("ods", "correspondance-code-insee-code-postal"), "FODRDataset")
})

test_that("get_records works", {
  dts1 <- fodr_dataset("ods", "correspondance-code-insee-code-postal")
  dts2 <- fodr_dataset("ods", "geoflar-departements")
  expect_is(df <- dts1$get_records(nrows = 10), "tbl_df")
  expect_equal(nrow(df), 10)
  expect_true("geo_shape" %in% names(dts2$get_records(nrow = 1)))
})