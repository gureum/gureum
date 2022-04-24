import urllib3
import json

URL = "https://opencollective.com/gureum/members/all.json"


def fetch_text(url):
    http = urllib3.PoolManager()
    html = http.request("GET", url).data
    return html


def sort_key(user):
    active_key = (user["createdAt"],)  # 가장 오래된 유저의 근사값
    inactive_key = -user["totalAmountDonated"], user["lastTransactionAt"]
    return (-user["isActive"], *(active_key if user["isActive"] else inactive_key))


def contributors(text):
    users = json.loads(text)
    users = [
        user for user in users if user["role"] not in ["CONTRIBUTOR", "HOST", "ADMIN"]
    ]
    users.sort(key=sort_key)
    return users


def summarize(user):
    import pprint

    github_name = None
    if user["profile"].startswith("https://opencollective.com/guest-"):
        link_name = "익명의 기여자"
    else:
        link_name = user["name"]

    image_markdown = f'<img src="{user["profile"]}/avatar.png" height="20px" />'
    profile_markdown = f"[{link_name}]({user['profile']}) "
    github_markdown = ""
    if user["github"]:
        github_name = user["github"].removeprefix("https://github.com/")
        github_markdown = f"@{github_name}"

    user_markdown = f"{image_markdown} {profile_markdown} {github_markdown}"
    return {
        "name": user["name"],
        "role": user["role"],
        "image": user["image"],
        "markdown": user_markdown,
    }


if __name__ == "__main__":
    html = fetch_text(URL)
    users = contributors(html)

    dedup = set()
    for user in map(summarize, users):
        if user["markdown"] in dedup:
            continue
        print("-", user["markdown"])
        dedup.add(user["markdown"])
