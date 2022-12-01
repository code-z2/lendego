import { GetServerSideProps, GetServerSidePropsContext, NextPage } from "next";

export const getServerSideProps: GetServerSideProps = async (
  context: GetServerSidePropsContext
) => {
  return {
    redirect: {
      destination: "/",
      permanent: false,
    },
  };
};

export default getServerSideProps;
