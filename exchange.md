#Description of currency exchange contract



##1. Deployment and setup



###1. Deployment



1. First deploy token and get token address = > tokenaddr

2. Deploy the currency exchange contract and obtain the exchange contract address = > exchange token addr



###2. Settings



1. Token contract owner, approve the token number specified in the token exchange contract = > approve (exchange token addr, totalamount) totalamount is the minimum unit

2. Call the setexchange method of the currency exchange contract to set the currency change information

1. setExchange(address myToken, uint decimals, uint totalAmount, uint userMaxAmount, uint price)

+Address mytoken: token address

+Uint decimals: token precision

+Uint totalamount: total amount of currency change. Here, for convenience, the input parameter is the number of tokens without precision, and 100 represents 100 tokens

+Uint usermaxamount: the maximum currency change amount of a single address, which is also a parameter without precision

+Uint price: TRX price of Token: 10 means 10trx = 1token

+ e.g. `setExchange(0x6E1E726E589Cf32d6AF50432007e30d480e31e37, 8, 10, 5, 2)`

+It means that the token address is 0x6e1e726e589cf32d6af50432007e30d480e31e37, the token accuracy is 8, a total of 10 coins are changed, no one can change up to 5 coins, and the price is 2trx one token

3. Set the starting time and duration of currency change

1. start(uint startTime, uint dayCount)

+Uint starttime: start time, UTC timestamp, 0 means immediate start

+Uint daycount: duration of currency change, 1 means 1 day

+* * only when setexchange and start are called can currency exchange be started**



##2. Change currency



1. exchange() payable

+According to the amount of TRX paid by the user, it will be automatically exchanged to the user's specified amount of token

+Multi payment partial return to user



2. exchangeAmount(address addr) returns (uint)

+Query the amount of currency changed at the specified address



3. Totalamount: the total amount of money changed by uint



4. Usermaxamount: uint maximum amount of currency exchange for a single address



5. Price: uint currency exchange price TRX



6. Remainexchange mount: the amount of remaining currency in the currency exchange contract



7. Mytoken: token contract address



8. Starttime: currency change start time UTC timestamp



9. Endtime: currency change end time UTC timestamp