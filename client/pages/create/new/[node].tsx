import { GetServerSideProps, GetServerSidePropsContext, NextPage } from "next";
import OrderCard from "../../../components/Cards/OrderCard";

const CreateNode: NextPage<{ node: string }> = ({ node }) => {
  return <OrderCard node={node} />;
};

export default CreateNode;

export const getServerSideProps: GetServerSideProps<{
  node: string;
}> = async (context: GetServerSidePropsContext) => {
  const nodeType = context.params?.node;

  if (nodeType == "lend" || nodeType == "borrow") {
    return {
      props: { node: nodeType as string },
    };
  }

  return {
    notFound: true,
  };
};
