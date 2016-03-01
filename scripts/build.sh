mkdir -p Builds
rm -rf Builds/eatnow-ios-staging.ipa

# cd /Users/caoer115/Documents/Projects/huawo/HuaWo
ipa build -w EatNow.xcworkspace -c Release -s EatNow --clean --archive --embed ./Certificates/AdHoc_com.leizh.EatNow.mobileprovision --identity "iPhone Distribution: Lei Zhang" --ipa Builds/eatnow-ios-staging.ipa --verbose

ipa distribute:pgyer -u 5427c5b05f45ed757a7c419632d125a5 -a 86560d2abca85062d87e292c261d6f3c -f Builds/eatnow-ios-staging.ipa
# ipa distribute:deploygate --api_token 147ff289fa8f9d80577e100f1ee2d870a2019389 --user_name caoer -f Builds/huawo-ios-staging.ipa




