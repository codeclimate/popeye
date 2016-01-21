Generate and output an `authorized_keys` file based on an IAM group.

![iam](http://cdn2.hubspot.net/hub/153377/file-18038864-gif/images/popeye_i_am_what_i_am_t_copy.gif)

## Usage

- Create a group in IAM
- Assign users to said group
- Have users upload public keys to their account

```
docker run \
  --env AWS_ACCESS_KEY_ID=... \
  --env AWS_SECRET_ACCESS_KEY=... \
  codeclimate/popeye --group GROUP
```

## Installation

Available on DockerHub
