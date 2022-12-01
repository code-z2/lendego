import { isAddress } from "ethers/lib/utils.js";
import { GetServerSideProps, GetServerSidePropsContext, NextPage } from "next";

const Profile: NextPage<{ address: string }> = ({ address }) => {
  return <div>hello from profile</div>;
};

export default Profile;

export const getServerSideProps: GetServerSideProps<{
  address: string;
}> = async (context: GetServerSidePropsContext) => {
  const addr = context.params?.address;

  if (addr && isAddress(addr as string)) {
    return {
      props: { address: addr as string },
    };
  }

  return {
    notFound: true,
  };
};
