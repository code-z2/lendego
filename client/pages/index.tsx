import Head from "next/head";
import Image from "next/image";
import DataCard from "../components/Cards/DataCard";
import LoanCard from "../components/Cards/LoanCard";
import Link from "../components/Link/Link";
import styles from "../styles/Home.module.css";

export default function Home() {
  return (
    <div>
      <LoanCard />
      <DataCard />
      <Link />
    </div>
  );
}
