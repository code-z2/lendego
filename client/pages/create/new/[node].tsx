import { GetServerSideProps, GetServerSidePropsContext, NextPage } from "next";

const CreateNode: NextPage<{ node: string }> = ({ node }) => {
  return <div>hello from {node}</div>;
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
