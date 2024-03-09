stripe_payment_ids = [
    "ch_3MX2abFsZJRtLc1j0exzseWz",
    "ch_3MWJEpFsZJRtLc1j1kECuwwJ",
    "ch_3MWIncFsZJRtLc1j0xJjhNpn",
    "ch_3MWGO6FsZJRtLc1j11VZdWx6",
    "ch_3MVoyOFsZJRtLc1j1RwjS9O9",
    "ch_3MVofxFsZJRtLc1j1PyRtOMp",
    "ch_3MVaGGFsZJRtLc1j1RSWSO5K",
    "ch_3MVaFwFsZJRtLc1j0BrL3eBP",
    "ch_3MVE9SFsZJRtLc1j1L5Oj59h",
    "ch_3MVE1hFsZJRtLc1j0btMZ6Zp",
    "ch_3MVDxqFsZJRtLc1j0uBoXV5d",
    "ch_3MUqimFsZJRtLc1j0XbZfihR",
    "ch_3MUSlBFsZJRtLc1j0emaM3DE",
    "ch_3MTlDbFsZJRtLc1j1Bnm2v5d",
    "ch_3MTSnfFsZJRtLc1j0rce3kiE",
    "ch_3MTSluFsZJRtLc1j0u18TkPi",
    "ch_3MTShrFsZJRtLc1j1LIdtUmw",
    "ch_3MTShDFsZJRtLc1j0ZTtIHq4",
    "ch_3MTSdNFsZJRtLc1j11mN6YHk",
    "ch_3MTScJFsZJRtLc1j1uGK0g88",
    "ch_3MTSaOFsZJRtLc1j0d9uFhAs",
    "ch_3MTSYSFsZJRtLc1j1CRsTPNT",
    "ch_3MTSXaFsZJRtLc1j015g4kWY",
    #"pi_3MPQV3FsZJRtLc1j144TUmjZ",
    "ch_3MRCzxFsZJRtLc1j0WREui9V",
    "ch_3MQUaPFsZJRtLc1j1dVslJoN",
    "ch_3MQUZnFsZJRtLc1j0dB4cj4H",
    "ch_3MQUXVFsZJRtLc1j1BrC97w0",
    "ch_3MQUTMFsZJRtLc1j1lsq60t6",
    "ch_3MQTHOFsZJRtLc1j1F501LjP",
    #"pi_3MOJ9IFsZJRtLc1j0xuSx3rZ",
    #"pi_3MOJ3GFsZJRtLc1j1wxksgnA",
]
stripe_payment_ids.each do |p|
    Payment.create(
        user:User.second,
        stripe_payment_id:p, 
        stripe_customer_id:"cus_MguGqSKZPZoiI3",
        stripe_card_id:"card_1LxWSDFsZJRtLc1jYE8XrYwc",
        price: 100,
        point: 100,
        status:"normal",
        is_succeeded:true,
        is_refunded:false
        )
end

Payment.create(
        user:User.second,
        stripe_payment_id:"ch_3MRDM3FsZJRtLc1j00ap4fC3", 
        stripe_customer_id:"cus_MguGqSKZPZoiI3",
        stripe_card_id:"card_1LxWSDFsZJRtLc1jYE8XrYwc",
        price: 4000,
        point: 4000,
        status:"normal",
        is_succeeded:true,
        is_refunded:false
        )


Payment.create(
        user:User.second,
        stripe_payment_id:"ch_3MRD7GFsZJRtLc1j0N4OQIyK", 
        stripe_customer_id:"cus_MguGqSKZPZoiI3",
        stripe_card_id:"card_1LxWSDFsZJRtLc1jYE8XrYwc",
        price: 1000,
        point: 1000,
        status:"normal",
        is_succeeded:true,
        is_refunded:false
        )