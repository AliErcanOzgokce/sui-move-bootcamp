import { BalanceChange } from "@mysten/sui/client";

interface Args {
  balanceChanges: BalanceChange[];
  senderAddress: string;
  recipientAddress: string;
}

interface Response {
  recipientSUIBalanceChange: number;
  senderSUIBalanceChange: number;
}

/**
 * Parses the balance changes as they are returned by the SDK.
 * Filters out and formats the ones that correspond to SUI tokens and to the defined sender and recipient addresses.
 */
export const parseBalanceChanges = ({
  balanceChanges,
  senderAddress,
  recipientAddress,
}: Args): Response => {
  const rec = balanceChanges.find(
    (balance) => {
      const owner = balance.owner as {AddressOwner:string}; 
      return owner.AddressOwner === recipientAddress;
    }
  );
  const sender = balanceChanges.find(
    (balance) => {
      const owner = balance.owner as {AddressOwner:string}; 
      return owner.AddressOwner === senderAddress;
    }
  );
  return {
    recipientSUIBalanceChange: Number(rec?.amount),
    senderSUIBalanceChange: Number(sender?.amount),
  };
};
