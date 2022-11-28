import Head from "next/head";
import Image from "next/image";
import LoanCard from "../components/Cards/LoanCard";
import styles from "../styles/Home.module.css";

export default function Home() {
  return (
    <div>
      <LoanCard />
    </div>
  );
}
