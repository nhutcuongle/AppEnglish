/**
 * Lấy public_id từ URL Cloudinary
 * Ví dụ:
 * https://res.cloudinary.com/.../lms/units/abc123.webp
 * => abc123
 */
export const getPublicIdFromUrl = (url) => {
  if (!url) return null;

  const parts = url.split("/");
  const filename = parts[parts.length - 1];
  return filename.split(".")[0];
};
