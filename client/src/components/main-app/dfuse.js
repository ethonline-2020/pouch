import React, {useState} from "react";
import {createDfuseClient} from "@dfuse/client";

const client = createDfuseClient({
  apiKey: "web_8da7f11232ae69bb230a73c1df04dbbf",
  network: "ropsten.eth.dfuse.io"
});
// You must use a `$cursor` variable so stream starts back at last marked cursor on reconnect!
const operation = `subscription($cursor: String!) {
    searchTransactions(indexName:CALLS, query:"-value:0 type:call", lowBlockNum: -1, cursor: $cursor) {
      undo cursor
      node { hash matchingCalls { from to value(encoding:ETHER) } }
    }
  }`;

let streamTransactionQuery = `
  subscription($hash: String!){
   transactionLifecycle(hash: $hash){
     previousState
     currentState
     transitionName
     transition{
       __typename

     ... on TrxTransitionInit {
         transaction {
         ...TransactionFragment
         }
         blockHeader {
         ...BlockHeaderFragment
         }
         trace {
         ...TransactionTraceFragment
         }
         confirmations
         replacedById
       }

     ...on TrxTransitionPooled {
         transaction {
         ...TransactionFragment
         }
       }

     ...on TrxTransitionMined {
         blockHeader {
         ...BlockHeaderFragment
         }
         trace {
         ...TransactionTraceFragment
         }
         confirmations
       }

     ...on TrxTransitionForked {
         transaction {
         ...TransactionFragment
         }
       }

     ...on TrxTransitionConfirmed {
         confirmations
       }

     ...on TrxTransitionReplaced {
         replacedById
       }

     }
   }
 }

 fragment TransactionFragment on Transaction {
   hash
   from
   to
   nonce
   gasPrice
   gasLimit
   value
   inputData
   signature {
     v
     s
     r
   }
 }

 fragment TransactionTraceFragment on TransactionTrace {
   hash
   from
   to
   nonce
   gasPrice
   gasLimit
   value
   inputData
   signature {
     v
     s
     r
   }
   cumulativeGasUsed
   publicKey
   index
   create
   outcome
 }

 fragment BlockHeaderFragment on BlockHeader {
   parentHash
   unclesHash
   coinbase
   stateRoot
   transactionsRoot
   receiptRoot
   logsBloom
   difficulty
   number
   gasLimit
   gasUsed
   timestamp
   extraData
   mixHash
   nonce
   hash
 }`;

// You would normally use your framework entry point and render using components,
// we are using pure HTML manipulation for sake of example simplicity.
async function main(txHash) {
  const stream = await client.graphql(
    streamTransactionQuery,
    message => {
      //   console.log(message.type);
      console.log(message);
      console.log(message.data.transactionLifecycle.transitionName);
      if (message.type === "data") {
        console.log("here");
        return message.data.transactionLifecycle.transitionName;
      }
    },
    {
      variables: {
        hash: txHash
      }
    }
  );

  // Waits until the stream completes, or forever
  await stream.join();
  await client.release();
}

export default main;
