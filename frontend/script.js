async function updateCounter() {
  try {
    let response = await fetch("https://bpv3ha6vakbpgfa7gazsibw6qa0ozuvv.lambda-url.us-east-1.on.aws/");
    let data = await response.json();
    const counter = document.getElementById("view-count");
    counter.innerText = data.views;
  } catch (error) {
    console.error('Error updating counter:', error);
  }
}

updateCounter();