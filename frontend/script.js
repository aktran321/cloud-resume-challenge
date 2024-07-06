async function updateCounter() {
  try {
    let response = await fetch(
      'https://g6thr4od50.execute-api.us-east-1.amazonaws.com/views'
    )
    let data = await response.json()
    console.log(data)
    const counter = document.getElementById('view-count')
    counter.innerText = data.views
  } catch (error) {
    console.error('Error updating counter:', error)
  }
}

updateCounter()
