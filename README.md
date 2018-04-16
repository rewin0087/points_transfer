# Points Transfer Promotions Exercise

## Background

One of our products involves us having a system where we run the exchange of loyalty program points between banks and airlines.

Banks will make points transfer requests on behalf of their customers and Kaligo will submit it to airlines. Banks will submit requests involving the customer's membership information, loyalty program, and amount of points to transact. 

One of the features of this system is the capability to run marketing campaigns and issue promotion points based on the type of campaign being run.

When we run marketing campaigns, based on the agreement with partners, promotion points may have to be issued immediately. Otherwise we'll separately issue points at the end of a campaign.

This exercise demonstrates a scenario where we apply promotion points to applicable points transactions:

1. Check if transfer request params are valid
2. Check if there's any promotion for the loyalty program requested for
2a. Check that the promotion period is still valid at this point in time
2b. Check that the promotion fulfillment type requires us to create promotion transactions immediately
2c. Check that the transferred points fulfills any applicable promotion threshold. (E.g. to qualify for promotion, customer must transfer at least X points)
3. Create the promotion points if the promotion is applicable. Compute the promotion points received by checking the type of promotion and the amount to fulfill
3a. Percentage type promotions are a proportion of the transferred points. (E.g. 10% promotion applied to 10,000 points transferred gives 1,000 points)
3b. Amount based promotions gives a fixed number of points based on the threshold of points transferred. (E.g. 1,000 promotion points are given when you transfer at least 10,000 points)

## Task

Your task is to refactor the `call` function in PointsTransfer class. Here are the guidelines:

* We use a SimpleOperation gem to simulate a service class processing the points transfer
* This operation returns a resultant state and outcome. `success?` returns the state of the operation. `outcome` returns either an array of Transactions recorded or an array of error messages if applicable.
* You can add more functions to PointsTransfer class as well as more classes, it's up to you.
* We've provided fake Repository classes simulating data in a database with the relevant functions. You should not modify the data faked as it covers all the general use cases. Neither should you need to modify the repository classes. However, you may modify the fake model classes in each repository as you deem fit. (E.g. add helper methods to each model)
* Use spec file provided. It covers all the cases, which means is the tests pass, your code works, if they fail, you made some mistake in refactoring. Do not modify the test file.
* If you struggle to understand the code, the spec file can help you by showing the different use cases.

What matters in the output:

* correctness - from the outside, the checkout function should work in exactly the same way as before; this is ensured by running the tests
* readability - the code should be easy to read, the flow of the checkout process should be easy to understand
* consistency - your Ruby code should be consistent, meaning if in 2 similar cases you use very different way of handling it (e.g. once you return false, once you raise error), it means something can be done better


## Delivery

Once you finish, you can send me the modified project, and email us. Or upload to private Github send us the link.

## Questions?

If you have any questions, drop me an e-mail!
