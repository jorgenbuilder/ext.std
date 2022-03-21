
actor {

    ////////////
    // Basic //
    //////////


    // @notice List of EXT modules this canister supports
    public query func extensions () : async [Text] {
        // ["@ext/common", "@ext/nonfungible"]
    };

    // @notice Transfers the ownership of an NFT from one address to another address
    // @dev If notify true attempt to notify recipient
    // @dev Token should be withheld from sender during notification to prevent reentrancy
    // @dev Transfer ownership of the token
    // @dev Push transaction to CAP
    // @err Amount must be one
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @err Token is listed for sale
    // @err Caller is not owner
    // @err Notification failure
    // @err Notification rejected
    // @err CannotNotify canister id cannot be coerced from an address
    public shared ({ caller }) func transfer ({
        from       : User;
        to         : User;
        token      : TokenIdentifier;
        amount     : Balance;
        memo       : Memo;
        notify     : Bool;
        subaccount : ?SubAccount;
    }) : async TransferResponse {
        // ...
    };

    // @notice Number of tokens owned by user
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @note Inconsistent with EIP/DIP720 `balanceOf`, which takes only address and returns balance across all tokens
    public query func balance ({ 
        user  : User; 
        token : TokenIdentifier;
    }) : Result.Result<Nat, CommonError> {
        // ...
    };

    // @notice Find the owner of an NFT
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @note analogous to EIP/DIP720 `ownerOf`
    public query func bearer (
        token : TokenIdentifier,
    ) : async Result.Result<AccountIdentifier, CommonError> {
        // ...
    };

    // @notice Count NFTs tracked by this contract
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    public query func supply (
        token : TokenIdentifier,  // Useless parameter (result of combining fungi/nonfungi std)
    ) : async Result.Result<Balance, CommonError> {
        // ...
    };

    // @notice Get entire ledger of tokens and owners
    public query func getRegistry () : async [(TokenIndex, AccountIdentifier)] {
        // ...
    };

    // @notice Get metadata for all tokens
    public query func getTokens () : async [(TokenIndex, Metadata)] {
        // ...
    };

    // @notice Get tokens owned by address
    // @err User has no tokens
    // @note Analogous to EIP720 `tokenOfOwnerByIndex`
    public query func tokens (
        aid : AccountIdentifier,
    ) : async Result.Result<[TokenIndex], CommonError> {
        // ...
    };

    // @notice Get tokens owned by address, plus listing and metadatablob
    // @err User has no tokens
    // @note Deprecated?
    public query func tokens_ext (
        aid : AccountIdentifier,
    ) : async Result.Result<[(TokenIndex, ?Listing, ?Blob)], CommonError> {
        // ...
    };

    // @notice Get metadata of token
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @return Metadata = Blob
    public query func metadata (
        token : TokenIdentifier,
    ) : async Result.Result<Metadata, CommonError> {
        // ...
    };

    // @notice Get listing and owner of token
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @note Deprecated?
    public query func details (
        token : TokenIdentifier,
    ) : async Result.Result<(AccountIdentifier, ?Listing), CommonError> {
        // ...
    };


    //////////////////
    // Marketplace //
    ////////////////


    // @notice Lock a listed NFT for marketplace sale
    // @dev Should attempt to settle any unfinalized transaction (async)
    // @dev Creates a unique payment address subaccount on this canister to handle the transaction
    // @dev Stores a lock on the NFT for 2 minutes
    // @dev Stores a record of pending transaction (buyer, seller, price, payment subaccount)
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @err Token is not listed
    // @err Listing is already locked
    // @err Price does not match listing price
    // @err Unfinalized settlement (listing has sold)
    public shared func lock (
        tokenid     : TokenIdentifier,
        price       : Nat64,
        address     : AccountIdentifier,
        subaccount  : SubAccount, // UNUSED. Included for backwards compatibility.
    ) : async Result.Result<AccountIdentifier, CommonError> {
        // ...
    };

    // @notice Validates the balance of and completes a marketplace transaction
    // @async NNS ledger query (do not assume state integrity after call)
    // @dev Read NNS ledger balance of transaction subaccount
    // @dev Disburse funds from canister subaccount
    // @dev Transfer token to buyer
    // @dev Store transaction history record (push to CAP)
    // @dev Clean up pending transaction state
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @err Insufficient funds sent
    // @err Lock has expired
    // @err Transaction does not exist
    public shared func settle (
        tokenid     : TokenIdentifier,
    ) : async Result.Result<(), CommonError> {
        // ...
    };

    // @notice List an NFT for sale on secondary markets
    // @dev Should attempt to settle any unfinalized transaction (async)
    // @dev If price is supplied, create listing
    // @dev If price is null, delete listing
    // @dev Clean up old pending transactions
    // @err InvalidToken (Token identifier cannot be decoded, token does not exist)
    // @err Unfinalized settlement (listing has sold)
    // @err Listing is already locked
    // @err Caller doesn't own token
    public shared ({ caller }) func list ({
        token           : TokenIdentifier;
        from_subaccount : ?SubAccount;
        price           : ?Nat64;
    }) : async Result.Result<(), CommonError> {
        // ...
    };

    // @notice Retrieve pending settlements
    // @return token, address, price
    public query func settlements () : async [(TokenIndex, AccountIdentifier, Nat64)] {
        // ...
    };

    // @notice Retrieve secondary markets transaction history
    public query func transactions () : async [Transaction] {
        // ...
    };

    // @notice Retrieve payments subaccounts for funds received by caller
    public query ({ caller }) func payments () : async ?[SubAccount] {
        // ...
    };

    // @notice Get all listed NFTs
    // @note Metadata is unused
    public query func listings () : async [(TokenIndex, Listing, Metadata)] {
        // ...
    };

    // @notice Retrieve pending transactions for all users
    public query func allSettlements () : async [(TokenIndex, Settlement)] {
        // ...
    };

    // @notice Retrieve payment subaccounts for all users
    public query func allPayments () : async [(Principal, [SubAccount])] {
        // ...
    };

    // @notice Clean out payment subaccounts which no longer have enough balance to pay a transaction fee (10_000 ICP8s)
    public query func clearPayments (
        seller      : Principal,
        payments    : [SubAccount],
    ) : () {
        // ...
    };

    // @notice Process all pending disbursements
    // @dev Iterate + process disbursement queue
    // @dev Put failed messages back into the queue
    public shared func cronDisbursements () : async () {
        // ...
    };

    // @notice Process all pending settlements
    public shared func cronSettlements () : async () {
        // ...
    };

    // @notice Process all pending CAP events
    // @dev Iterate + process CAP queue
    // @dev Put failed messages back into the queue
    public shared func cronCapEvents () : async () {
        // ...
    };

}