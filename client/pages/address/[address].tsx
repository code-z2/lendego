import { isAddress } from "ethers/lib/utils.js";
import { GetServerSideProps, GetServerSidePropsContext, NextPage } from "next";
import ProfileHeader from "../../components/Headers/ProfileHeader";
import Linkto from "../../components/Link/Link";
import ActivePositions from "../../sections/Profile/Active";
import ArchivedPositions from "../../sections/Profile/Archived";
import DefaultedPositions from "../../sections/Profile/Defaulted";
import OpenPositions from "../../sections/Profile/Open";

const Profile: NextPage<{ address: string }> = ({ address }) => {
  return (
    <div>
      <ProfileHeader address={address} />
      <div className="pt-5">
        <Linkto />
      </div>
      <OpenPositions address={address} />
      <ActivePositions address={address} />
      <ArchivedPositions address={address} />
      <DefaultedPositions address={address} />
    </div>
  );
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
