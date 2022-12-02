import { isAddress } from "ethers/lib/utils.js";
import { GetServerSideProps, GetServerSidePropsContext, NextPage } from "next";
import ProfileHeader from "../../components/Headers/ProfileHeader";

const Profile: NextPage<{ address: string }> = ({ address }) => {
  return <ProfileHeader address={address} />;
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
