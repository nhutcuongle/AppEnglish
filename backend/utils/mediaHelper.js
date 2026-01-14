/**
 * Trích xuất YouTube ID từ URL
 */
export const extractYoutubeId = (url) => {
  if (!url) return null;
  const match = url.match(/^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/);
  return match && match[2].length === 11 ? match[2] : null;
};

/**
 * Xử lý các file upload và youtube videos từ request
 * @param {Object} files - req.files
 * @param {Object} body - req.body
 * @returns {Object} - { images, audios, videos }
 */
export const processMedia = (files, body) => {
  const result = {};

  // 1. Xử lý Images
  if (files?.images) {
    const imageCaptions = Array.isArray(body.imageCaptions)
      ? body.imageCaptions
      : body.imageCaptions ? [body.imageCaptions] : [];
    result.images = files.images.map((file, index) => ({
      url: file.path,
      caption: imageCaptions[index] || "",
      order: index + 1,
    }));
  }

  // 2. Xử lý Audios
  if (files?.audios) {
    const audioCaptions = Array.isArray(body.audioCaptions)
      ? body.audioCaptions
      : body.audioCaptions ? [body.audioCaptions] : [];
    result.audios = files.audios.map((file, index) => ({
      url: file.path,
      caption: audioCaptions[index] || "",
      order: index + 1,
    }));
  }

  // 3. Xử lý Videos (Upload + YouTube)
  let videos = [];
  
  // Video upload từ máy
  if (files?.videos) {
    const videoCaptions = Array.isArray(body.videoCaptions)
      ? body.videoCaptions
      : body.videoCaptions ? [body.videoCaptions] : [];
    videos = files.videos.map((file, index) => ({
      type: "upload",
      url: file.path,
      caption: videoCaptions[index] || "",
      order: index + 1,
    }));
  }

  // Video YouTube từ link
  if (body.youtubeVideos) {
    const youtubeUrls = Array.isArray(body.youtubeVideos)
      ? body.youtubeVideos
      : [body.youtubeVideos];
    const youtubeCaptions = Array.isArray(body.youtubeVideoCaptions)
      ? body.youtubeVideoCaptions
      : body.youtubeVideoCaptions ? [body.youtubeVideoCaptions] : [];

    const youtubeItems = youtubeUrls.map((url, index) => ({
      type: "youtube",
      url,
      youtubeId: extractYoutubeId(url),
      caption: youtubeCaptions[index] || "",
      order: videos.length + index + 1,
    }));
    videos = [...videos, ...youtubeItems];
  }

  if (videos.length > 0) {
    result.videos = videos;
  }

  return result;
};
