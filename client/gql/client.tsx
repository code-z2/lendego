import { ApolloClient, ApolloProvider, InMemoryCache } from "@apollo/client";
import { FC, PropsWithChildren } from "react";

const SubgraphApolloProvider: FC<PropsWithChildren> = ({ children }) => {
  const client = new ApolloClient({
    uri: "https://api.thegraph.com/subgraphs/name/peteruche21/arcmon",
    cache: new InMemoryCache(),
  });

  return <ApolloProvider client={client}>{children}</ApolloProvider>;
};
 
export default SubgraphApolloProvider;