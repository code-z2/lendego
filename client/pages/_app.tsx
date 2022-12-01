import "../styles/globals.css";
import { Session } from "next-auth";
import { SessionProvider } from "next-auth/react";
import {
  RainbowKitSiweNextAuthProvider,
  GetSiweMessageOptions,
} from "@rainbow-me/rainbowkit-siwe-next-auth";
import type { AppProps } from "next/app";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import "@rainbow-me/rainbowkit/styles.css";
import {
  getDefaultWallets,
  RainbowKitProvider,
  Chain,
  lightTheme,
  darkTheme,
} from "@rainbow-me/rainbowkit";
import { chain, configureChains, createClient, WagmiConfig } from "wagmi";
import { jsonRpcProvider } from "wagmi/providers/jsonRpc";
import { publicProvider } from "wagmi/providers/public";
import LayoutComponent from "../components/Layout";
import useStore from "../store/useStore";
import { useEffect } from "react";

const testnetEvmos: Chain = {
  id: 9000,
  name: "Evmos Testnet",
  network: "Evmos",
  iconUrl: "/evmos_logo.svg",
  iconBackground: "#fff",
  nativeCurrency: {
    decimals: 18,
    name: "Evmos",
    symbol: "tEVMOS",
  },
  rpcUrls: {
    default: "https://eth.bd.evmos.dev:8545",
  },
  blockExplorers: {
    default: { name: "evm explorer", url: "https://evm.evmos.dev" },
  },
  testnet: true,
};

const { chains, provider } = configureChains(
  [testnetEvmos],
  [
    jsonRpcProvider({ rpc: (chain) => ({ http: chain.rpcUrls.default }) }),
    publicProvider(),
  ]
);

const { connectors } = getDefaultWallets({
  appName: "Inst-Paymaster",
  chains,
});

const wagmiClient = createClient({
  autoConnect: true,
  connectors,
  provider,
});

const queryClient = new QueryClient();

const getSiweMessageOptions: GetSiweMessageOptions = () => ({
  statement: "Sign in to The Alchemy of Money",
});

export default function App({ Component, pageProps }: AppProps) {
  const state = useStore((state) => state);
  useEffect(() => {
    state.setAll("9000");
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <WagmiConfig client={wagmiClient}>
      <SessionProvider refetchInterval={0} session={pageProps.session}>
        <RainbowKitSiweNextAuthProvider
          getSiweMessageOptions={getSiweMessageOptions}
        >
          <RainbowKitProvider
            modalSize="compact"
            chains={chains}
            theme={{
              lightMode: lightTheme(),
              darkMode: darkTheme(),
            }}
          >
            <QueryClientProvider client={queryClient}>
              <LayoutComponent>
                <Component {...pageProps} />
              </LayoutComponent>
            </QueryClientProvider>
          </RainbowKitProvider>
        </RainbowKitSiweNextAuthProvider>
      </SessionProvider>
    </WagmiConfig>
  );
}
