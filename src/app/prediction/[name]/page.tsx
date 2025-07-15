import React from "react";

export default async function Page({ params }: any) {
  const { name } = params;
  const [age, gender, nationality] = await Promise.all([
    fetch(`https://api.agify.io?name=${name}`).then((res) => res.json()),
    fetch(`https://api.genderize.io?name=${name}`).then((res) => res.json()),
    fetch(`https://api.nationalize.io?name=${name}`).then((res) => res.json()),
  ]);

  return (
    <div className="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden md:max-w-2xl m-3 p-4">
      <div className="p-8">
        <div className="uppercase tracking-wide text-sm text-indigo-500 font-semibold">
          Personal Info
        </div>
        <div className="mt-2 text-lg font-medium text-black">Age: {age?.age}</div>
        <div className="mt-2 text-lg font-medium text-black">Gender: {gender?.gender}</div>
        <div className="mt-2 text-lg font-medium text-black">
          Nationality: {nationality?.country?.[0]?.country_id || "Unknown"}
        </div>
      </div>
    </div>
  );
}
