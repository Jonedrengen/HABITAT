a_dataframe <- data.frame( 
    sample_id = c("S1", "S2", "S3"),
    training = c(1, 0, 1),
    class_A = c(0.1, 0.3, 0.6),
    class_B = c(0.9, 2.7, 0.4)
)



for (class_col in a_dataframe) {
    print(class(class_col))
    print(all(class_col >= 0 & class_col <= 1))
}